pwd
mkdir -p /home/vscode/.local/state/mume/
cp -fr misc/present/md-preview-enhanced/style.less /home/vscode/.local/state/mume/
git config --global user.email 'kunalpathak13@gmail.com'
#source ./anamoly_detection_venv/bin/activate
pip install --no-cache-dir -r ./requirements.txt
echo "§§§§§§§§§§§§§done executing postStart script§§§§§§§§§§§§§"
