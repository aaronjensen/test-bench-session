require_relative '../../automated_init'

context "Session" do
  context "Comment" do
    context "Block Error" do
      context "Exception in Block" do
        session = Session.new
        error = nil

        begin
          session.comment("Outer comment") do
            session.comment("Inner comment") do
              raise "Some error"
            end
          end
        rescue => error
        end

        test! "Error is raised" do
          refute(error.nil?)
        end

        context "Block Depth" do
          test "Reset to zero" do
            assert(session.instance_variable_get(:@comment_block_depth).zero?)
          end
        end

        context "Events" do
          sink = session.telemetry.sink
          events = sink.received_events.map(&:type)

          test "Events are recorded in order until error" do
            assert(events[0] == :Commented)
            assert(events[1] == :CommentBlockStarted)
            assert(events[2] == :Commented)
          end
        end
      end

      context "Deep Nesting" do
        session = Session.new
        nesting_depth = 5

        nesting_depth.times do |i|
          session.comment("Comment level #{i}") do
            session.comment("Inner at level #{i}")
          end
        end

        context "Events" do
          sink = session.telemetry.sink
          events = sink.received_events.map(&:type)

          test "Only outermost blocks record block events" do
            block_started_count = events.count(:CommentBlockStarted)
            block_finished_count = events.count(:CommentBlockFinished)

            assert(block_started_count == nesting_depth)
            assert(block_finished_count == nesting_depth)
          end
        end

        test "Block depth is zero after completion" do
          assert(session.instance_variable_get(:@comment_block_depth).zero?)
        end
      end

      context "Empty Block" do
        session = Session.new

        session.comment("Comment with empty block") do
          # Empty block
        end

        context "Events" do
          sink = session.telemetry.sink
          events = sink.received_events.map(&:type)

          test "Block events are still recorded" do
            assert(events[0] == :Commented)
            assert(events[1] == :CommentBlockStarted)
            assert(events[2] == :CommentBlockFinished)
          end
        end

        test "Block depth is zero" do
          assert(session.instance_variable_get(:@comment_block_depth).zero?)
        end
      end
    end
  end
end 