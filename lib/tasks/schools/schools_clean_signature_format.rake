namespace :schools do
  desc "Convertit toutes les signatures d'écoles en PNG non entrelacé"
  task desinterlace_signatures: :environment do
    School.where.not(signature_attachment: nil).find_each do |school|
      DesinterlaceSchoolSignatureJob.perform_later(school.id)
    end
    puts "Jobs de désentrelacement lancés pour toutes les signatures d'écoles."
  end
end
