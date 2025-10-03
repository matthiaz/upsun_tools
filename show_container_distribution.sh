#!/usr/bin/env bash
# usage: bash show_container_distribution.sh $PROJECT_ID $ENV

CMD="platform"
#if command -v upsun >/dev/null 2>&1; then
#    CMD="upsun"
#fi

PROJECT_ID=""

if [ $# -eq 0 ]; then
    # try finding the .platform/local folder
    PROJECT_ID=$(grep -F 'id:' ".upsun/local/project.yaml" | cut -d' ' -f2)

    if [ -n "$PROJECT_ID" ]; then
        echo ""
    else
        PROJECT_ID=$(grep -F 'id:' ".platform/local/project.yaml" | cut -d' ' -f2)
        if [ -n "$PROJECT_ID" ]; then
            echo ""
        else
            echo "Error: no project ID found. Please supply the project_id as parameter:" >&2
            echo "" >&2
            echo "Usage: " >&2
            echo "  bash show_container_distribution.sh \$PROJECT_ID \$ENV_NAME (defaults to: main)" >&2
            echo "" >&2
            echo "For example: " >&2
            echo "  bash show_container_distribution.sh szr3gqubqrd2y master" >&2
            exit 1
        fi
    fi
else
    PROJECT_ID="$1"
fi


ENV="${2:-main}"
sum_cpu=0
sum_mem=0

echo "PROJECT_ID = $PROJECT_ID"
echo "ENV = $ENV"
echo "CMD = $CMD"

$CMD auth:info >/dev/null 2>&1 || {
    echo "Not logged in, asking user to login"
    $CMD login
}

$CMD e:info -e "$ENV" -p $PROJECT_ID >/dev/null 2>&1 || {
    echo "ERROR: Selected environment '$ENV' does not exist, please enter the environment name as second parameter."
    $CMD e:list -p $PROJECT_ID --no-inactive
    exit 1
}

echo ""
printf "\e[4;38;2;96;70;255m%-35s %10s %10s %10s %10s %10s\e[0m\n" \
  "Service" "CPU" "Mem(MB)" "CPU (%)" "Mem (%)" "Disk (%)"

echo ""
for service in $($CMD mem --columns service -1 --format csv --no-header -p $PROJECT_ID -e $ENV); do

    cpu=$($CMD cpu --columns limit,percent --service=$service -1 --format csv --no-header -p $PROJECT_ID -e $ENV | tr -d '\n')
    cpu_limit=$(echo "$cpu" | cut -d, -f1)
    cpu_usage=$(echo "$cpu" | cut -d, -f2)

    mem=$($CMD mem --columns limit,percent --service=$service -1 --format csv --no-header --bytes -p $PROJECT_ID -e $ENV | tr -d '\n')
    mem_limit=$(echo "$mem" | cut -d, -f1)
    mem_usage=$(echo "$mem" | cut -d, -f2)
    mem_limit=$((mem_limit / 1024 / 1024))

    disk_percent=$($CMD disk --columns percent --service=$service -1 --format csv --no-header --bytes -p $PROJECT_ID -e $ENV | tr -d '\n')

    sum_cpu=$(awk "BEGIN{print $cpu_limit + $sum_cpu}")
    sum_mem=$((mem_limit + sum_mem))

    # Make it red if above 90%
    cpu_color=$([ "${cpu_usage:-0}" -ge 90 ] 2>/dev/null && echo -e "\e[38;2;255;0;0m")
    mem_color=$([ "${mem_usage:-0}" -ge 90 ] 2>/dev/null && echo -e "\e[38;2;255;0;0m")
    disk_color=$([ "${disk_percent:-0}" -ge 90 ] 2>/dev/null && echo -e "\e[38;2;255;0;0m")

    printf "\e[38;2;221;249;51m%-35s\e[0m %10s %10s ${cpu_color}%10s\e[0m ${mem_color}%10s\e[0m ${disk_color}%10s\e[0m\n" \
      "$service" "$cpu_limit" "$mem_limit" "$cpu_usage" "$mem_usage" "$disk_percent"
done
echo " "

# Total row (same color as header, #6046ff)
printf "\e[38;2;96;70;255m%-35s %10.2f %10s %10s %10s %10s\e[0m\n" \
  "Total" "$sum_cpu" "$sum_mem" "" "" ""

echo " "
echo "Plan:"
$CMD project:info subscription -p $PROJECT_ID | grep -e 'plan:' -e production | sed -e 's/medium/max_cpu: 2.09, max_memory: 3072/g'



