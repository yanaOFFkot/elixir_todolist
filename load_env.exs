if File.exists?(".env") do
  IO.puts("Loading environment variables from .env file")

  try do
    Dotenvy.load!(".env", override: true)
  rescue
    UndefinedFunctionError -> IO.puts("Dotenvy is not available")
  end
end
