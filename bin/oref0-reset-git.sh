#!/bin/bash

# Delete git lock / history if necessary to recover from corrupted .git objects
#
# Released under MIT license. See the accompanying LICENSE.txt file for
# full terms and conditions
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.

# must be run from within a git repo to do anything useful
# remove old lockfile if still present
self=$(basename $0)
BACKUP_AREA=${1-${BACKUP_AREA-/var/cache/openaps-ruination}}
function usage ( ) {

cat <<EOF
$self
$self - Wipe out all history, forcibly re-initialzize openaps from scratch.
EOF
}

case "$1" in
  --help|help|-h)
    usage
    exit 0
    ;;
esac
test ! -d $BACKUP_AREA && BACKUP_AREA=/tmp
BACKUP="$BACKUP_AREA/git-$(date +%s)"

find .git/index.lock -mmin +5 -exec rm {} \; 2>/dev/null
# first, try oref0-fix-git-corruption.sh to preserve git history up to last good commit
echo "Attempting to fix git corruption.  Please wait 15s."
oref0-fix-git-corruption &
sleep 15 && killall oref0-fix-git-corruption
# if git repository is too corrupt to do anything, mv it to /tmp and start over.

git status > /dev/null || (echo "Saving backup to: $BACKUP" > /dev/stderr; mv .git $BACKUP; openaps init . )
