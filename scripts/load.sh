SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

echo "Loading Scripts..."
for SCRIPT in $(ls ${SCRIPT_DIR}/autoload); do
    echo -n "."
    source "${SCRIPT_DIR}/autoload/${SCRIPT}"
done


