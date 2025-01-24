module TestBench
  class Session
    module Controls
      module Events
        module CommentBlockStarted
          extend EventData

          def self.example(process_id: nil, time: nil)
            process_id ||= self.process_id
            time ||= self.time

            Session::Events::CommentBlockStarted.build(process_id:, time:)
          end

          def self.random
            Random.example
          end

          def self.process_id
            ProcessID.example
          end

          def self.time
            Time.example
          end

          module Random
            extend EventData

            def self.example(process_id: nil, time: nil)
              process_id ||= ProcessID.random
              time ||= Time.random

              CommentBlockStarted.example(process_id:, time:)
            end
          end
        end
      end
    end
  end
end 