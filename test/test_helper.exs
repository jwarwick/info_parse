Dynamo.under_test(InfoParse.Dynamo)
Dynamo.Loader.enable
ExUnit.start

defmodule InfoParse.TestCase do
  use ExUnit.CaseTemplate

  # Enable code reloading on test cases
  setup do
    Dynamo.Loader.enable
    :ok
  end
end
