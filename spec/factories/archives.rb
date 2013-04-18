# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.modify do
  factory :archive do
    name Faker::Lorem.sentence(1)
  end
end
