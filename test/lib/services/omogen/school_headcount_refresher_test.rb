require 'test_helper'

module Services
  module Omogen
    class SchoolHeadcountRefresherTest < ActiveSupport::TestCase
      include ThirdPartyTestHelpers

      setup do
        @code_uai = '0590116F'
        @school = create(:school, code_uai: @code_uai)
        @troisieme = Grade.find_by(short_name: 'troisieme')
        stub_omogen_auth
        @token = 'token'
      end

      def sygne_student(ine:, classe:, code_sexe:, code_uai: @code_uai, code_mef: '10310019110')
        {
          'ine' => ine, 'nom' => 'X', 'prenom' => 'Y', 'dateNaissance' => '2010-01-01',
          'codeSexe' => code_sexe, 'codeUai' => code_uai, 'anneeScolaire' => 2025,
          'niveau' => '2116', 'libelleNiveau' => '3EME', 'codeMef' => code_mef,
          'classe' => classe, 'codeStatut' => 'ST'
        }
      end

      def stub_school_eleves(students_by_niveau: {}, status: 200)
        Services::Omogen::Sygne::MEFSTAT4_CODES.each do |niveau|
          body = (students_by_niveau[niveau] || []).to_json
          uri = URI("#{ENV['SYGNE_URL']}/etablissements/#{@code_uai}/eleves?niveau=#{niveau}")
          stub_request(:get, uri)
            .with(headers: headers_with_token(token: @token, uri: uri))
            .to_return(status: status, body: body, headers: {})
        end
      end

      test 'creates classrooms with class_size and writes stats without creating students' do
        stub_school_eleves(students_by_niveau: {
                             '2116' => [
                               sygne_student(ine: 'A1', classe: '3E4', code_sexe: '1'),
                               sygne_student(ine: 'A2', classe: '3E4', code_sexe: '2'),
                               sygne_student(ine: 'A3', classe: '3E5', code_sexe: '1')
                             ]
                           })

        assert_no_difference 'Users::Student.count' do
          Services::Omogen::SchoolHeadcountRefresher.new(@school).call
        end

        assert_equal 2, @school.class_rooms.find_by(name: '3E4').class_size
        assert_equal 1, @school.class_rooms.find_by(name: '3E5').class_size

        stat = SchoolStat.find_by(school: @school)
        assert_equal 3, stat.effectif
        assert_equal Date.current, stat.date_reference
      end

      test 'deletes empty stale classrooms but keeps classrooms with registered students' do
        empty_cr = create(:class_room, name: 'OLD-EMPTY', school: @school, grade: @troisieme)
        kept_cr = create(:class_room, name: 'OLD-KEPT', school: @school, grade: @troisieme)
        create(:student, school: @school, class_room: kept_cr, grade: @troisieme)

        stub_school_eleves(students_by_niveau: {
                             '2116' => [sygne_student(ine: 'A1', classe: '3E4', code_sexe: '1')]
                           })

        Services::Omogen::SchoolHeadcountRefresher.new(@school).call

        refute ClassRoom.exists?(empty_cr.id), 'la classe vide non vue par SYGNE doit être supprimée'
        assert ClassRoom.exists?(kept_cr.id), 'la classe avec élèves inscrits doit être conservée'
        assert_equal 0, kept_cr.reload.class_size
      end

      test 'writes gender breakdown for registered users' do
        create(:student, school: @school, gender: 'f', grade: @troisieme)
        create(:student, school: @school, gender: 'm', grade: @troisieme)

        stub_school_eleves(students_by_niveau: {
                             '2116' => [sygne_student(ine: 'A1', classe: '3E4', code_sexe: '1')]
                           })

        Services::Omogen::SchoolHeadcountRefresher.new(@school).call

        stat = SchoolStat.find_by(school: @school)
        assert_equal 2, stat.nb_utilisateurs
        assert_equal 1, stat.nb_filles
        assert_equal 1, stat.nb_garcons
      end

      test 'records effectif nil and does not raise when Sygne fails' do
        stub_school_eleves(status: 500)

        assert_nothing_raised do
          Services::Omogen::SchoolHeadcountRefresher.new(@school).call
        end

        stat = SchoolStat.find_by(school: @school)
        assert_not_nil stat
        assert_nil stat.effectif
      end

      test 'is idempotent across same-day re-runs' do
        stub_school_eleves(students_by_niveau: {
                             '2116' => [sygne_student(ine: 'A1', classe: '3E4', code_sexe: '1')]
                           })

        Services::Omogen::SchoolHeadcountRefresher.new(@school).call
        assert_difference 'SchoolStat.count', 0 do
          Services::Omogen::SchoolHeadcountRefresher.new(@school).call
        end
        assert_equal 1, @school.class_rooms.where(name: '3E4').count
      end
    end
  end
end
