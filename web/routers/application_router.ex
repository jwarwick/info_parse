defmodule ApplicationRouter do
  use Dynamo.Router

  prepare do
    # Pick which parts of the request you want to fetch
    # You can comment the line below if you don't need
    # any of them or move them to a forwarded router
    conn.fetch([:cookies, :params])
  end

  # It is common to break your Dynamo into many
  # routers, forwarding the requests between them:
  # forward "/posts", to: PostsRouter

  get "/" do
    conn = conn.assign(:title, "Main Page")
    render conn, "index.html"
  end

  get "/directory" do
    conn = conn.assign(:title, "School Directory")
    conn = conn.assign(:classrooms, InfoParse.Directory.ordered_classrooms)
    conn = conn.assign(:start_student_id, 0)
    render conn, "directory.html"
  end

  get "/directory/:start_id" do
    start_id = binary_to_integer(conn.params[:start_id])
    conn = conn.assign(:title, "School Directory (starting from student_id #{start_id})")
    conn = conn.assign(:classrooms, InfoParse.Directory.ordered_classrooms)
    conn = conn.assign(:start_student_id, start_id)
    render conn, "directory.html"
  end

  get "/students" do
    conn = conn.assign(:title, "Students")
    conn = conn.assign(:students, InfoParse.Directory.ordered_students)
    render conn, "students.html"
  end

  get "/parents" do
    conn = conn.assign(:title, "Parents")
    conn = conn.assign(:parents, InfoParse.Directory.ordered_parents)
    render conn, "parents.html"
  end

  # def get_students(classroom_id), do: InfoParse.Directory.ordered_students(classroom_id)
end
