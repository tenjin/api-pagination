require 'spec_helper'

describe ApiPagination do
  let(:collection) {(1..100).to_a}
  let(:active_record_relation) {double("ActiveRecord_Relation").as_null_object}

  describe "#paginate" do
    if ENV['PAGINATOR'].to_sym == :kaminari
      context 'Using kaminari' do
        describe '.paginate' do
          it 'uses the array total and paginates the requested page' do
            paginated_collection = ApiPagination.paginate(
              collection,
              page: 2,
              per_page: 30
            ).first

            expect(paginated_collection.total_count).to eq(100)
            expect(paginated_collection.to_a).to eq((31..60).to_a)
          end

          context 'configured not to include the total' do
            before { ApiPagination.config.include_total = false }

            context 'and paginating an array' do
              it 'should not call without_count on the collection' do
                expect(collection).to_not receive :without_count
                ApiPagination.paginate(collection)
              end
            end
            context 'and paginating an active record relation' do
              it 'should call without_count on the relation' do
                expect(active_record_relation).to receive :without_count
                ApiPagination.paginate(active_record_relation)
              end
            end

            after { ApiPagination.config.include_total = true }
          end
        end

        describe '.pages_from' do
          subject { described_class.pages_from(collection) }

          context 'on empty collection' do
            let(:collection) { ApiPagination.paginate([], page: 1).first }

            it { is_expected.to be_empty }
          end
        end
      end
    end

    if ENV['PAGINATOR'].to_sym == :will_paginate
      context 'Using will_paginate' do
        context 'passing in total_entries in options' do
          it 'should set total_entries using the passed in value' do
            paginated_collection = ApiPagination.paginate(collection, total_entries: 3000).first
            expect(paginated_collection.total_entries).to eq(3000)
          end
        end

        context 'passing in collection only' do
          it 'should set total_entries using the size of the collection ' do
            paginated_collection = ApiPagination.paginate(collection).first
            expect(paginated_collection.total_entries).to eq(100)
          end
        end
      end
    end
  end
end
