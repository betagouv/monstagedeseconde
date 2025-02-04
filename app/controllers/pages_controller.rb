# frozen_string_literal: true

class PagesController < ApplicationController
  WEBINAR_URL = ENV.fetch('WEBINAR_URL').freeze
  layout 'homepage', only: %i[home
                              pro_landing
                              regional_partners_index
                              school_management_landing
                              statistician_landing
                              student_landing
                              search_companies
                              maintenance_estivale]

  def register_to_webinar
    authorize! :subscribe_to_webinar, current_user
    current_user.update(subscribed_to_webinar_at: Time.zone.now)
    redirect_to WEBINAR_URL,
                allow_other_host: true
  end

  def offers_with_sector
    InternshipOffer.includes([:sector])
  end

  def student_landing
    @faqs = get_faqs('student')
    @resources = get_resources('student')
    @school_weeks_list, @preselected_weeks_list = current_user_or_visitor.compute_weeks_lists
  end

  def pro_landing
    @faqs = get_faqs('pro')
    @resources = get_resources('pro')
  end

  def school_management_landing
    @faqs = get_faqs('education')
    @resources = get_resources('education')
    @school_weeks_list, @preselected_weeks_list = current_user_or_visitor.compute_weeks_lists
  end

  def statistician_landing
    @faqs = get_faqs('statistician')
    @resources = get_resources('statistician')
  end

  def home
    if params[:logout] == 'educonnect'
      redirect_to ENV['EDUCONNECT_LOGOUT_URL'], allow_other_host: true, status: :see_other
    end
    @faqs = get_faqs('student')
  end

  def search_companies
    @faqs = get_faqs('student')
    @resources = get_resources('student')
  end

  def maintenance_estivale
    @waiting_list_entry = WaitingListEntry.new
  end

  def waiting_list
    @waiting_list_entry = WaitingListEntry.new(waiting_list_params)
    message = if @waiting_list_entry.save
                'Votre e-mail a été ajouté à la liste d\'attente.'
              else
                'Une erreur est survenue lors de l\'ajout de votre e-mail à la liste d\'attente.'
              end
    redirect_to '/maintenance_estivale.html', notice: message
  end

  def maintenance_messaging
    hash = {
      subject: "Message de la page de maintenance de #{user_params[:name]}",
      message: user_params[:message],
      name: user_params[:name],
      email: user_params[:email]
    }

    GodMailer.maintenance_mailing(**hash).deliver_later
    redirect_to '/maintenance_estivale.html', notice: 'Votre message a bien été envoyé'
  end

  def user_params
    params.require(:user).permit(:name, :email, :message)
  end

  def waiting_list_params
    params.require(:waiting_list_entry).permit(:email)
  end

  private

  def link_resolver
    @link_resolver ||= Prismic::LinkResolver.new(nil) do |link|
      # URL for the category type
      if link.type == 'faq'
        '/faq/' + link.uid
      # Default case for all other types
      else
        '/'
      end
    end
  end

  def get_faqs(tag)
    return [] if ENV['PRISMIC_URL'].blank? || ENV['PRISMIC_API_KEY'].blank? || Rails.env.test?

    api = Prismic.api(ENV['PRISMIC_URL'], ENV['PRISMIC_API_KEY'])

    begin
      response = api.query([
                             Prismic::Predicates.at('document.type', 'faq'),
                             Prismic::Predicates.at('document.tags', [tag])
                           ],
                           { 'orderings' => '[my.faq.order]' })
    rescue StandardError => e
      puts "Error: #{e}"
      return
    end

    serialize_faq(response.results)
  end

  def get_resources(tag)
    api = Prismic.api(ENV['PRISMIC_URL'], ENV['PRISMIC_API_KEY'])

    begin
      response = api.query([
                             Prismic::Predicates.at('document.type', 'resource'),
                             Prismic::Predicates.at('document.tags', [tag])
                           ])
    rescue StandardError => e
      puts "Error: #{e}"
      return
    end

    serialize_resource(response.results)
  end

  def serialize_faq(results)
    results.map do |doc|
      {
        question: doc['faq.question'].as_text,
        answer: doc['faq.answer'].as_html(link_resolver),
        url: doc['faq.url'].try(:as_text)
      }
    end
  end

  def serialize_resource(results)
    # Group by school level
    grouped_by_school = results.group_by { |doc| doc['resource.school_level'].as_text }

    grouped_by_school.transform_values! do |docs|
      # Group by category
      grouped_by_category = docs.group_by { |doc| doc['resource.category'].as_text }

      grouped_by_category.transform_values! do |category_docs|
        category_docs.map do |doc|
          url = doc.fragments['url']&.url || doc.fragments['file']&.url
          {
            url: url,
            title: doc['resource.title'].as_text
          }
        end
      end
    end

    grouped_by_school
  end
end
