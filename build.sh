

build_metrics() {
  BUN=bun
  HOME=$(pwd)
  if command -v docker $> /dev/null
  then
    BUN="docker run -it --rm --name bun -v `pwd`:/vimrc --workdir=/vimrc/tools/git-metrics oven/bun"
    HOME=/vimrc
  fi
  echo "Building git-metrics!"
  set -x
  cd tools/git-metrics
  $BUN -- install
  $BUN build ./git-metrics.ts --compile --outfile $HOME/bin/git-metrics
  set +x
  cd ../..
  echo "Complete! New binary: $(ls bin/git-metrics)"
}

build_metrics
