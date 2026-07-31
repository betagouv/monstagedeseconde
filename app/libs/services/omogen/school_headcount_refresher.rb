module Services
  module Omogen
    # Rafraîchit les effectifs (class_size) des classes d'un établissement à partir d'un
    # comptage SYGNE (sans créer d'élèves) et écrit la statistique hebdomadaire associée.
    class SchoolHeadcountRefresher
      def initialize(school, sygne: nil)
        @school = school
        @sygne = sygne
      end

      def call
        tally = sygne.sygne_count_by_school(@school.code_uai)
        total_effectif = upsert_class_rooms(tally)
        write_stats(total_effectif)
        @school
      rescue Services::Omogen::SygneApiError => e
        Rails.logger.error("[headcount] #{@school.code_uai} ignoré : #{e.message}")
        write_stats(nil)
        nil
      end

      private

      attr_reader :school

      def sygne
        @sygne ||= Services::Omogen::Sygne.new
      end

      def upsert_class_rooms(tally)
        seen_class_room_ids = []
        total = 0
        tally.each do |(name, grade_id), data|
          next if data[:count].zero?

          class_room = ClassRoom.find_or_create_by(name: name, school_id: @school.id, grade_id: grade_id)
          class_room.update_columns(class_size: data[:count])
          seen_class_room_ids << class_room.id
          total += data[:count]
        end
        cleanup_class_rooms(seen_class_room_ids)
        total
      end

      # Classes non vues dans SYGNE lors de ce run :
      # - supprimées si aucune ligne élève associée (aligné sur le garde-fou du dashboard) ;
      # - sinon conservées avec class_size = 0 (effectif réel renvoyé par SYGNE).
      def cleanup_class_rooms(seen_class_room_ids)
        stale = @school.class_rooms.where.not(id: seen_class_room_ids)
        stale.left_joins(:students).where(users: { id: nil }).distinct.destroy_all
        @school.class_rooms.where.not(id: seen_class_room_ids).update_all(class_size: 0)
      end

      def write_stats(effectif)
        registered = @school.students.kept
        SchoolStat.find_or_initialize_by(
          school_id: @school.id, date_reference: Date.current
        ).update!(
          effectif: effectif,
          nb_utilisateurs: registered.count,
          nb_filles: registered.where(gender: 'f').count,
          nb_garcons: registered.where(gender: 'm').count
        )
      end
    end
  end
end
