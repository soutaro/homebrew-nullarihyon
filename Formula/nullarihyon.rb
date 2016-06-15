class Nullarihyon < Formula
  desc "Nullability check for Objective-C implementation"
  homepage "https://github.com/soutaro/nullarihyon"
  url "https://github.com/soutaro/nullarihyon/archive/1.5.0.zip"
  sha256 "71287b63c4e8519564bfa438a0ffcbe41ace7836c508b4b427831b2d4e089203"

  depends_on "cmake" => :build

  CLANG_RESOURCE_NAME = "clang_binary_mac"
  resource CLANG_RESOURCE_NAME do
    url "http://llvm.org/releases/3.8.0/clang+llvm-3.8.0-x86_64-apple-darwin.tar.xz"
    sha256 "e5a961e04b0e1738bbb5b824886a34932dc13b0af699d1fe16519d814d7b776f"
  end

  def install
    llvm_root = buildpath/"vendor/llvm"
    cmake_build_path = buildpath/"build"

    resource(CLANG_RESOURCE_NAME).stage(llvm_root)

    cmake_build_path.mkpath
    Dir.chdir(cmake_build_path.to_s) do
      system "cmake",
              "-DLLVM_ROOT=#{llvm_root}",
              "-DCMAKE_INSTALL_PREFIX=#{prefix}",
              "-DCMAKE_BUILD_TYPE=Release",
              "-G",
              "Unix Makefiles",
              buildpath

      system "make", "install"
    end
  end

  test do
    (testpath/"test.m").write <<EOT
@import Foundation;

@interface TestClass : NSObject
@end

@implementation TestClass

- (void)test {
  NSString * _Nonnull x = nil;
}

@end
EOT
    require "open3"
    output, _ = Open3.capture2e(bin/"nullarihyon", "check", "--sdk", "macosx", testpath/"test.m")

    output !~ /Error/
  end
end
