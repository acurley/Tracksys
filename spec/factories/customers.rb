# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.modify do
  factory :customer do
  end
end

FactoryGirl.define do
  factory :customer_external, parent: :customer do
    association :academic_status, factory: :external_academic_status
  end
end