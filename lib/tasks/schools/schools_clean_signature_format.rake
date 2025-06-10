namespace :schools do
  desc "Convertit toutes les signatures d'écoles en PNG non entrelacé"
  task desinterlace_signatures: :environment do
    School.joins(:signature_attachment).find_each do |school|
      puts "Processing school #{school.id}"
      DesinterlaceSchoolSignatureJob.perform_later(school.id)
    end
    puts "Jobs de désentrelacement lancés pour toutes les signatures d'écoles."
  end
end
