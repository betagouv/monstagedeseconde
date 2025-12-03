
    # frozen_string_literal: true

module Users
  class MultiCoordinator < User
    belongs_to :multi_activity, optional: false

    # siret character varying(14),
    # sector_id integer,
    # employer_name character varying(120),
    # employer_chosen_name character varying(120) NOT NULL,
    # employer_address character varying(250),
    # employer_chosen_address character varying(250) NOT NULL,
    # city character varying(60) NOT NULL,
    # zipcode character varying(6) NOT NULL,
    # street character varying(300) NOT NULL,
    # phone character varying(20) NOT NULL,
    # multi_activity_id bigint NOT NULL,
  end
end