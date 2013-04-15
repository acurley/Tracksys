# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :customer do
    first_name 'joe'
    last_name 'smith'
    email 'joe@example.com'
  end
end
