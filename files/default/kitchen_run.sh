#!/bin/bash -xe

if ! test -d ${FROM_COOKBOOK} ; then
  mkdir -p ${FROM_COOKBOOK}
  pushd ${FROM_COOKBOOK}
  git init
  git remote add origin http://github.com/dmlb2000/${FROM_COOKBOOK}
  popd
fi
pushd ${FROM_COOKBOOK}
git fetch --all
git checkout ${REVISION}
if ! kitchen test ; then
  kitchen destroy
  rc=-1
else
  rc=0
fi
popd
exit $rc
