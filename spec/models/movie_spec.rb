require 'rails_helper'

RSpec.describe Movie, type: :model do
  subject { FactoryBot.build(:movie) }

  describe 'Validations' do
    context 'presence validations' do
      it 'is valid with valid attributes' do
        expect(subject).to be_valid
      end

      it 'is invalid without a title' do
        subject.title = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include("can't be blank")
      end

      it 'is invalid without a year' do
        subject.year = nil
        expect(subject).not_to be_valid
        expect(subject.errors[:year]).to include("can't be blank")
      end
    end

    context 'year format validation' do
      it 'is invalid if year is not a number' do
        subject.year = 'Two Thousand'
        expect(subject).not_to be_valid
        expect(subject.errors[:year]).to include('is not a number')
      end

      it 'is invalid if year is a decimal number' do
        subject.year = 2020.5
        expect(subject).not_to be_valid
        expect(subject.errors[:year]).to include('must be an integer')
      end
    end

    context 'published_at format validation' do
      it 'is valid with a correct date format for published_at' do
        subject.published_at = '2020-01-01'
        expect(subject).to be_valid
      end
    end

    context 'uniqueness validation for title and year' do
      before { FactoryBot.create(:movie, title: subject.title, year: subject.year) }

      it 'is invalid with a duplicate title and year' do
        expect(subject).not_to be_valid
        expect(subject.errors[:title]).to include('The movie has already been registered for the specified year.')
      end

      it 'is valid with the same title but a different year' do
        subject.year = subject.year + 1
        expect(subject).to be_valid
      end

      it 'is valid with a different title in the same year' do
        subject.title = 'Different Title'
        expect(subject).to be_valid
      end
    end
  end
end
