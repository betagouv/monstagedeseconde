def populate_invitations
  author = Users::SchoolManagement.all.first
  if author.present?
    invitation = author.invitations.build(
      first_name: 'Julie',
      last_name: 'Durand',
      email: "julie.durand@#{author.school.email_domain_name}",
      role: 'teacher',
      sent_at: Time.current
    )
    invitation.save!
  else
    puts '------------'
    puts "School manager with email #{lycee_school_manager_email} not found. Invitation not created."
    puts '------------'
  end
end

call_method_with_metrics_tracking([:populate_invitations])
