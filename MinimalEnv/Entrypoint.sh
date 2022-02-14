#!/bin/sh -xv

# Simple script to test deployments

gprefix="https://github.com/wwPDB"
giprefix="git+https://github.com/wwPDB"
base=/tmp/onedep_admin/base_packages

if [ "x$GIT_USER" = "x" -o "x$GIT_PASS" = "x" ] ; then
    echo "Must set GIT_USER and GIT_PASS environment variables"
    exit 1
fi

cd /tmp

cat > /tmp/credential-helper.sh <<EOF
#!/bin/bash
echo username=$GIT_USER
echo password=$GIT_PASS
EOF

git config --global credential.helper "/bin/bash /tmp/credential-helper.sh"

python3 -m venv /tmp/venv3
. /tmp/venv3/bin/activate

git clone -b py3cleanup $gprefix/onedep_admin

python3 -m pip install -U pip wheel setuptools
python3 -m pip install -U pip wheel setuptools
python3 -m pip install -r $base/pre-requirements.txt -c $base/constraints.txt
python3 -m pip install -r $base/requirements.txt -c $base/constraints.txt --find-links=/tmp/

for i in `cat $base/requirements_wwpdb_dependencies.txt` ; do

    # Install from git is painfully slow. Faster to checkout on our own
    if [ $i = "py-wwpdb_apps_validation" ]; then
	git clone -q $recurs $gprefix/$i.git
	cd $i
	python3 setup.py -q sdist
	python3 -m pip install -U dist/* -c $base/constraints.txt --find-links=/tmp/
	cd ..
	rm -rf $i
    else
	python3 -m pip install $giprefix/$i.git -c $base/constraints.txt
    fi
    
done
