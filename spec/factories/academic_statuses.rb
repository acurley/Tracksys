# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:name) {|i| "Department #{i}"}

  factory :academic_status do
    name
    factory :external_academic_status do
      name 'Non-UVA'
    end
  end
end
