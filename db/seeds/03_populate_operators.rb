def populate_operators
  Operator.find_or_create_by!(name: "JobIRL",
                              website: "",
                              target_count: 32)
end

call_method_with_metrics_tracking([:populate_operators])