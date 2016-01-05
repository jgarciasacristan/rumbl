defmodule Rumbl.VideoChannel do
	use Rumbl.Web, :channel
  alias Rumbl.AnnotationView
	
	def join("videos:" <> video_id, _params, socket) do
		{:ok, id} = Rumbl.Permalink.cast(video_id)
		video = Repo.get!(Rumbl.Video, video_id)
		annotations = Repo.all(
      from a in assoc(video, :annotations),
			order_by: [desc: a.at],
			limit: 200,
			preload: [:user])
		resp = %{annotations: Phoenix.View.render_many(annotations,
																									AnnotationView,
																									"annotation.json")}
		
    {:ok, resp, assign(socket, :video_id, id)}
	end

	def handle_in("new_annotation", params, socket) do
		user = socket.assigns.current_user
		changeset =
		  user
		  |> build(:annotations, video_id: socket.assigns.video_id)
		  |> Rumbl.Annotation.changeset(params)

		case Repo.insert(changeset) do
		  {:ok, annotation} ->
				broadcast! socket, "new_annotation", %{
				user: Rumbl.UserView.render("user.json", %{user: user}),
        body: annotation.body,
        at: annotation.at
        }
        {:reply, :ok, socket}
			{:error, changeset} ->
				{:reply, {:error, %{errors: changeset}}, socket}
		end
  end 
end
