
#!/bin/sh

bundle exec bin/rails db:schema:load
bundle exec bin/rails db:migrate
bundle exec bin/rails db:seed
bundle exec bin/rails infra:notify_deployed