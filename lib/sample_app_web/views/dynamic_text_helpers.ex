defmodule SampleAppWeb.DynamicTextHelpers do
  alias SampleAppWeb.StaticPageView, as: SPView
  alias SampleAppWeb.UserView
  alias SampleAppWeb.SessionView

  @base_title "Phoenix Tutorial Sample App"

  def page_title(assigns) do
    assigns
    |> get_page_title()
    |> put_base_title()
  end

  defp put_base_title(nil), do: @base_title

  defp put_base_title(title) do
    [title, " | ", @base_title]
  end

  defp get_page_title(%{action: :home}), do: "Home"

  defp get_page_title(%{view_module: SPView, action: :help}), do: "Help"

  defp get_page_title(%{view_module: SPView, action: :about}), do: "About"

  defp get_page_title(%{view_module: SPView, action: :contact}), do: "Contact"

  defp get_page_title(%{view_module: UserView, action: :new}), do: "Sign up"

  defp get_page_title(%{view_module: SessionView, action: :new}), do: "Log in"

  defp get_page_title(%{view_module: _, action: _, title: title}), do: title

  defp get_page_title(_), do: nil
end
