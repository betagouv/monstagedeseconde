def populate_operators
  Operator.find_or_create_by!(name: "Un stage et après !",
                  website: "",
                  logo: 'Logo-un-stage-et-apres.jpg',
                  target_count: 120)
  # this one is for test
  Operator.find_or_create_by!(name: "JobIRL",
                  website: "",
                  logo: 'Logo-jobirl.jpg',
                  target_count: 32)
  Operator.find_or_create_by!(name: "Le Réseau",
                  website: "",
                  logo: 'Logo-le-reseau.jpg',
                  target_count: 710)
  Operator.find_or_create_by!(name: "Institut Télémaque",
                  website: "",
                  logo: 'Logo-le-reseau.jpg',
                  target_count: 1200)
  Operator.find_or_create_by!(name: "Myfuture",
                  website: "",
                  logo: 'Logo-my-future.jpg',
                  target_count: 1200)
  Operator.find_or_create_by!(name: "Les entreprises pour la cité (LEPC)",
                  website: "",
                  logo: 'Logo-les-entreprises-pour-la-cite.jpg',
                  target_count: 1200)
  Operator.find_or_create_by!(name: "Tous en stage",
                  website: "",
                  logo: 'Logo-tous-en-stage.jpg',
                  target_count: 1200)
  Operator.find_or_create_by!(name: "Viens voir mon taf",
                  website: "",
                  logo: 'Logo-viens-voir-mon-taf.jpg',
                  target_count: 1200)
end

call_method_with_metrics_tracking([:populate_operators])