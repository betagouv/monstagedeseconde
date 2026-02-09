module SplittableOffer
  extend ActiveSupport::Concern

  included do
    def split_offer
      grades = self.grades.to_a.dup
      return if grades.size < 2

      stats = self.stats
      create_troisieme_offer = true
      weeks_seconde = self.weeks.select { |week| week.number >= 24 && week.number <= 27}
      # offer_year = self.weeks.order(:year,:number).last.year #since secnde offer has weeks in june
      # weeks_seconde = self.weeks.select { |week| week.year == offer_year && week.number >= 24 && week.number <= 27}
      weeks_troisieme_quatrieme = self.weeks.to_a - weeks_seconde.to_a

      seconde_favorites_user_ids = Favorite.joins(:user)
                                           .where(internship_offer_id: id)
                                           .where(user: { grade_id: Grade.seconde.id, discarded_at: nil })
                                           .pluck(:user_id)
      troisieme_favorites_user_ids = Favorite.joins(:user)
                                             .where(internship_offer_id: id)
                                             .where(user: { grade_id: Grade.troisieme_et_quatrieme.ids, discarded_at: nil })
                                             .pluck(:user_id)
      applications_for_troisieme_quatrieme = InternshipApplication.joins(:student)
                                                                  .where(internship_offer_id: id)
                                                                  .where(student: { grade_id: Grade.troisieme_et_quatrieme.ids, discarded_at: nil })
      applications_for_seconde = InternshipApplication.joins(:student)
                                                      .where(internship_offer_id: id)
                                                      .where(student: { grade_id: Grade.seconde.id, discarded_at: nil })
      res_schools = split_reserved_schools
      if from_api?
        PrettyConsole.say_in_yellow("InternshipOffer ID: #{id} is from API it reduces grades to \"seconde\" only.")
        self.grades = [Grade.seconde]
        # No change on internship applications as from_api offers don't have any
        # no change on history, just keep it as is
        self.schools = res_schools[:schools_seconde]
        self.favorites = Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: id)
        self.weeks = weeks_seconde
        save!
      else # weekly framed , multi offers
        PrettyConsole.say_in_yellow("InternshipOffer ID: #{id} is associated to multiple grades: #{grades.map(&:name).join(', ')}")

        # weeks separation analysis
        message = "Unexpected error: No weeks for troisieme/quatrieme found in ##{id}"
        if weeks_troisieme_quatrieme.empty?
          PrettyConsole.say_in_red(message)
          Rails.logger.error(message)
          create_troisieme_offer = false
        end

        message = "Unexpected error: No weeks for seconde found in ##{id}"
        if weeks_seconde.empty?
          PrettyConsole.say_in_red(message)
          Rails.logger.error(message)
          # in this case we cannot split the offer seconde offer is troisieme offer
          self.grades = grades - [Grade.seconde]
          save!
          return
        end
        # --- weeks separation done

        # duplication
        new_offer = dup if create_troisieme_offer
        seconde_offer = self

        # some restrictions on original offer
        seconde_offer.grades = [Grade.seconde]
        seconde_offer.weeks = weeks_seconde
        seconde_offer.mother_id = nil
        Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: id)
                .update_all(internship_offer_id: seconde_offer.id)
        # seconde_offer.favorites = Favorite.where(user_id: seconde_favorites_user_ids, internship_offer_id: offer.id)
        seconde_offer.favorites.reload
        seconde_offer.schools = res_schools[:schools_seconde]
        seconde_offer.reload.save!

        if create_troisieme_offer
          new_offer.grades = grades.to_a - [Grade.seconde]
          new_offer.weeks = weeks_troisieme_quatrieme
          new_offer.mother_id = id
          new_offer.created_at = created_at
          new_offer.updated_at = updated_at
          new_offer.from_doubling_task = true
          if new_offer.valid? && new_offer.from_doubling_task_save!
            print "-"
          else
            error_message = "Failed to create new InternshipOffer for grade: #{new_offer.grades.map(&:name).join(', ')}. Errors: #{new_offer.errors.full_messages.join(', ')}"
            PrettyConsole.say_in_red(error_message)
          end

          # reassign favorites when students exist or when offer still is valid
          unless troisieme_favorites_user_ids.empty? || new_offer.last_date < Date.today
            Favorite.where(user_id: troisieme_favorites_user_ids, internship_offer_id: id)
                    .update_all(internship_offer_id: new_offer.id)
          end
          new_offer.save!
        end

        # reassign applications - order matters here
        unless applications_for_seconde.empty? && applications_for_troisieme_quatrieme.empty?
          if create_troisieme_offer
            applications_for_troisieme_quatrieme.each do |application|
              application.update!(internship_offer_id: new_offer.id)
            end
          end
          unless applications_for_seconde.empty?
            applications_for_seconde.each do |application|
              application.update!(internship_offer_id: seconde_offer.id)
            end
          end
        end

        # reassign inappropriate_offer is not in the scope here
        if create_troisieme_offer
          # reassign users_internship_offers_histories
          seconde_offer.duplicate_history(new_offer)

          # reassign reserved_schools
          new_offer.schools = res_schools[:schools_troisieme_quatrieme]
          # save the associations
          new_offer.save!
        end
        seconde_offer.save!
      end
    end

    def split_reserved_schools
      schools_seconde = schools.select do |school|
        school.school_type == 'lycee' || school.school_type == 'college_lycee'
      end
      schools_troisieme_quatrieme = schools.select do |school|
        school.school_type == 'college' || school.school_type == 'college_lycee'
      end
      {schools_seconde:, schools_troisieme_quatrieme:}
    end

    def duplicate_history(new_offer)
      histories = UsersInternshipOffersHistory.where(internship_offer_id: id)
      histories.find_each do |history|
        views = history.views
        UsersInternshipOffersHistory.create(
          user_id: history.user_id,
          internship_offer_id: new_offer.id,
          views: views,
          created_at: history.created_at,
          updated_at: history.updated_at
        )
        print '.'
      end
    end
  end
end