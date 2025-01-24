require_relative '../../automated_init'

context "Session" do
  context "Comment" do
    context "Block" do
      session = Session.new

      control_text = Controls::Comment::Text.example
      control_inner_text = "Some inner text"

      session.comment(control_text, false) do
        session.comment(control_inner_text, false)
      end

      context "Events" do
        context "Outer Comment" do
          commented = session.telemetry.events(Session::Events::Commented)[0]

          test! "Recorded" do
            refute(commented.nil?)
          end

          context "Attributes" do
            context "Text" do
              text = commented.text

              comment text.inspect
              detail "Control: #{control_text.inspect}"

              test do
                assert(text == control_text)
              end
            end
          end
        end

        context "Block Started" do
          recorded = session.telemetry.one_event?(Session::Events::CommentBlockStarted)

          test "Recorded" do
            assert(recorded)
          end
        end

        context "Inner Comment" do
          inner_commented = session.telemetry.events(Session::Events::Commented)[1]

          test! "Recorded" do
            refute(inner_commented.nil?)
          end

          context "Attributes" do
            context "Text" do
              text = inner_commented.text

              comment text.inspect
              detail "Control: #{control_inner_text.inspect}"

              test do
                assert(text == control_inner_text)
              end
            end
          end
        end

        context "Block Finished" do
          recorded = session.telemetry.one_event?(Session::Events::CommentBlockFinished)

          test "Recorded" do
            assert(recorded)
          end
        end

        context "Events Order" do
          sink = session.telemetry.sink
          events = sink.received_events.map do |event_data|
            case event_data.type
            when :Commented
              Session::Events::Commented
            when :CommentBlockStarted
              Session::Events::CommentBlockStarted
            when :CommentBlockFinished
              Session::Events::CommentBlockFinished
            end
          end.compact

          test "Events are recorded in the correct order" do
            assert(events[0] == Session::Events::Commented)
            assert(events[1] == Session::Events::CommentBlockStarted)
            assert(events[2] == Session::Events::Commented)
            assert(events[3] == Session::Events::CommentBlockFinished)
          end
        end
      end
    end
  end
end
