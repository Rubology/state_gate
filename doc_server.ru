port = 9292

use Rack::Static,
  :urls => ["/images", "/js", "/css", "/panel", "/i", "/classes", "/files"],
  :root => "doc"

run lambda { |env|
  [
    200,
    {
      'Content-Type'  => 'text/html',
      'Cache-Control' => 'public, max-age=86400'
    },
    File.open('doc/index.html', File::RDONLY)
  ]
}
