FactoryGirl.modify do
  factory :academic_status do
  end
end

FactoryGirl.define do
  factory :external_academic_status, parent: :academic_status do
    name 'Non-UVA'
  end
end
