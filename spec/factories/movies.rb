FactoryBot.define do
  factory :movie do
    title { 'Sample Movie' }
    genre { 'Drama' }
    year { 2020 }
    country { 'United States' }
    published_at { Date.today }
    description { 'Sample description for testing' }
  end
end
