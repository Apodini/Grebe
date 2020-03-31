class Grebe < Formula
  desc "Simplifies the gRPC-Swift development workflow."
  homepage "https://github.com/Apodini/Grebe"
  url "https://github.com/Apodini/Grebe/archive/1.0.0.tar.gz"
  sha256 "911b36788ea1a2eada8cf56d77b0c2c8c39df5515da8c43dee8dbd62aa75e66e"
  
  def install
    system "swift", "build",
        "--product", "grebe",
        "--configuration", "release",
        "--disable-sandbox"
    bin.install '.build/release/grebe'
  end
end
