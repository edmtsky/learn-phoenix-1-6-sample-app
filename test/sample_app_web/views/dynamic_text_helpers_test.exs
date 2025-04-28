defmodule SampleAppWeb.DynamicTextHelpersTest do
  use SampleAppWeb.ConnCase, async: true
  alias SampleAppWeb.StaticPageView, as: SPV
  alias SampleAppWeb.DynamicTextHelpers, as: DTH

  @base_title "Phoenix Tutorial Sample App"

  test "page_title helper", %{conn: _conn} do
    assert to_string(DTH.page_title(%{action: :home})) == "Home | #{@base_title}"

    assert to_string(DTH.page_title(%{view_module: SPV, action: :help})) ==
             "Help | #{@base_title}"

    assert to_string(DTH.page_title(%{view_module: SPV, action: :about})) ==
             "About | #{@base_title}"
  end
end
