ActiveRecord::Schema[7.1].define(version: 20_241_031_222_829) do
  enable_extension 'pgcrypto'
  enable_extension 'plpgsql'

  create_table 'movies', id: :uuid, default: -> { 'gen_random_uuid()' }, force: :cascade do |t|
    t.string 'title'
    t.string 'genre'
    t.integer 'year'
    t.string 'country'
    t.date 'published_at'
    t.text 'description'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end
end
