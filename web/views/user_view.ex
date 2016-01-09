defmodule Rumbl.UserView do
	use Rumbl.Web, :view
	alias Rumbl.User

	def first_name(%User{name: name}) do
	  name
		|> String.split(" ")
		|> Enum.at(0)
	end

	def render("user.json", %{user: user}) do
		%{id: user.id, username: user.username}
	end

	def translate_error({msg, opts}) do
    String.replace(msg, "%{count}", to_string(opts[:count]))
  end

  def translate_error(msg), do: msg
end
