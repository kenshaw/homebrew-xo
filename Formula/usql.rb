$pkg     = "github.com/xo/usql"
$ver     = "v0.11.0"
$hash    = "aabf703abe3a9e8d0823bbf74838ce6e3ffce862af2dfce4a2d571f2c73a4263"

$cmdver  = $ver[1..-1]
$tags    = %w(most sqlite_app_armor sqlite_icu sqlite_fts5 sqlite_introspect sqlite_json1 sqlite_stat4 sqlite_userauth sqlite_vtable no_adodb)
$ldflags = "-s -w -X #{$pkg}/text.CommandVersion=#{$cmdver}"

class Usql < Formula
  desc     "universal command-line SQL client interface"
  homepage "https://#{$pkg}"
  head     "https://#{$pkg}.git"
  url      "https://#{$pkg}/archive/#{$ver}.tar.gz"
  sha256   $hash

  option "with-odbc", "Build with ODBC (unixodbc) support"

  depends_on "go" => :build
  depends_on "icu4c" => :build

  if build.with? "odbc" then
    $tags   << "odbc"
    depends_on "unixodbc"
  end

  def install
    (buildpath/"src/#{$pkg}").install buildpath.children

    cd "src/#{$pkg}" do
      system "go", "mod", "download"
      system "go", "build",
        "-tags",    $tags.join(" "),
        "-ldflags", $ldflags,
        "-o",       bin/"usql"
    end
  end

  test do
    output = shell_output("#{bin}/usql --version")
    assert_match "usql #{$cmdver}", output
  end
end
