module StandardProcedure
  class User
    class Root < StandardProcedure::User
      def can?(perform_command, on_target)
        return true
      end
    end
  end
end
