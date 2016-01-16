require_relative '../../helper'

class Repositext
  class Subtitle
    describe Operation do

      let(:contentChangeDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "1234567",
              before: "@word3 word4 word5",
              after: "@word3 word4",
            },
          ],
          operationId: '123',
          operationType: :contentChange,
        }
      }
      let(:deleteDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "1234567",
              before: "@word3 word4 word5",
              after: nil,
              afterStid: "4567890",
            },
          ],
          operationId: '123',
          operationType: :delete,
        }
      }
      let(:insertDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "1234567",
              before: nil,
              after: "@word3 word4 word5",
              afterStid: "4567890",
            },
          ],
          operationId: '123',
          operationType: :insert,
        }
      }
      let(:mergeDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "2345678",
              before: "@word1",
              after: "@word1 word2",
            },
            {
              stid: "5678901",
              before: "@word2",
              after: nil,
            },
          ],
          operationId: '123',
          operationType: :merge,
        }
      }
      let(:moveLeftDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "8901234",
              before: "@word1 word2",
              after: "@word1",
            },
            {
              stid: "3456789",
              before: "@word3 word4",
              after: "@word2 word3 word4",
            },
          ],
          operationId: '123',
          operationType: :moveLeft,
        }
      }
      let(:moveRightDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "8901234",
              before: "@word1 word2",
              after: "@word1 word2 word3",
            },
            {
              stid: "3456789",
              before: "@word3 word4",
              after: "@word4",
            },
          ],
          operationId: '123',
          operationType: :moveLeft,
        }
      }
      let(:splitDefaultAttrs){
        {
          affectedStids: [
            {
              stid: "9012345",
              before: "@word1 word2 word3 word4",
              after: "@word1 word2",
            },
            {
              stid: "1234567",
              before: null,
              after: "@word3 word4",
            },
          ],
          operationId: '123',
          operationType: :split,
        }
      }

      describe '.from_hash and .to_hash (roundtrip)' do

        %w[
          contentChangeDefaultAttrs
          deleteDefaultAttrs
          insertDefaultAttrs
          mergeDefaultAttrs
          moveLeftDefaultAttrs
          moveRightDefaultAttrs
        ].each do |attrs_name|
          it "handles #{ attrs_name }" do
            attrs = self.send(attrs_name)
            roundtrip_hash = Operation.new_from_hash(attrs).to_hash
            roundtrip_hash.must_equal(attrs)
          end
        end

      end

    end
  end
end
