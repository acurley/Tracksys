# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :bibl do
    sequence(:title) {|i| "Works of Diderot Volume #{i}"}
    sequence(:barcode) {|i| "X#{'%09d' % i}"}
  end
end
