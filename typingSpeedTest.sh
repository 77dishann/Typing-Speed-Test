*#!/bin/bash  

# Color codes  
RED='\033[0;31m'  
GREEN='\033[0;32m'  
YELLOW='\033[1;33m'  
BLUE='\033[0;34m'  
MAGENTA='\033[0;35m'  
CYAN='\033[0;36m'  
NC='\033[0m' # No Color  

# Array of random sentences with different difficulty levels  
sentences=(  
  "Pack my box with five dozen liquor jugs.|easy"  
  "How vexingly quick daft zebras jump!|medium"  
  "Bright vixens jump; dozy fowl quack.|easy"  
  "The five boxing wizards jump quickly.|medium"  
  "Crazy Fredrick bought many very exquisite opal jewels.|hard"  
  "Jinxed wizards pluck ivy from the big quilt.|medium"  
  "Quick zephyrs blow, vexing daft Jim.|hard"  
  "Sphinx of black quartz, judge my vow.|hard"  
  "Two driven jocks help fax my big quiz.|medium"  
  "Five quacking zephyrs jolt my wax bed.|hard"  
  "The quick brown fox jumps over the lazy dog.|easy"  
  "Amazingly few discotheques provide jukeboxes.|medium"  
  "Watch Jeopardy!, Alex Trebek's fun TV quiz game.|hard"  
)  

# Function to display animated text  
animate_text() {  
  local text="$1"  
  for ((i=0; i<${#text}; i++)); do  
    echo -n "${text:$i:1}"  
    sleep 0.05  
  done  
  echo  
}  

# Function to calculate WPM  
calculate_wpm() {  
  local words=$1  
  local time_seconds=$2  
  echo "scale=2; $words / ($time_seconds / 60)" | bc  
}  

# Function to calculate accuracy  
calculate_accuracy() {  
  local typed="$1"  
  local original="$2"  
  local len=${#original}  
  local correct=0  

  for ((i=0; i<len; i++)); do  
    if [ "${typed:$i:1}" == "${original:$i:1}" ]; then  
      ((correct++))  
    fi  
  done  

  echo "scale=2; ($correct / $len) * 100" | bc  
}  

# Function to count words in a sentence  
count_words() {  
  echo "$1" | wc -w | awk '{print $1}'  
}  

# Function to get random sentence with difficulty level  
get_random_sentence() {  
  local difficulty="$1"  
  local filtered=()  
  
  for sentence in "${sentences[@]}"; do  
    if [[ "$sentence" == *"|$difficulty" ]]; then  
      filtered+=("${sentence%|*}")  
    fi  
  done  
  
  if [ ${#filtered[@]} -eq 0 ]; then  
    echo "No sentences available for this difficulty level."  
    return 1  
  fi  
  
  local index=$((RANDOM % ${#filtered[@]}))  
  echo "${filtered[$index]}"  
}  

# Function to display typing test with color feedback  
display_results() {  
  local original="$1"  
  local typed="$2"  
  local time_taken="$3"  
  local wpm="$4"  
  local accuracy="$5"  
  
  echo -e "\n${BLUE}Results:${NC}"  
  
  # Display original vs typed with color coding  
  echo -e "${YELLOW}Original text:${NC}"  
  echo -n "  "  
  for ((i=0; i<${#original}; i++)); do  
    if [ "${typed:$i:1}" == "${original:$i:1}" ]; then  
      echo -ne "${GREEN}${original:$i:1}${NC}"  
    else  
      echo -ne "${RED}${original:$i:1}${NC}"  
    fi  
  done  
  echo  
  
  echo -e "${YELLOW}Your text:${NC}"  
  echo -n "  "  
  for ((i=0; i<${#typed}; i++)); do  
    if [ "${typed:$i:1}" == "${original:$i:1}" ]; then  
      echo -ne "${GREEN}${typed:$i:1}${NC}"  
    else  
      echo -ne "${RED}${typed:$i:1}${NC}"  
    fi  
  done  
  echo  
  
  # Display metrics with color based on performance  
  echo -e "${YELLOW}Time taken:${NC}    $time_taken seconds"  
  
  if (( $(echo "$wpm >= 40" | bc -l) )); then  
    echo -e "${YELLOW}Typing speed:${NC}  ${GREEN}$wpm WPM${NC}"  
  elif (( $(echo "$wpm >= 20" | bc -l) )); then  
    echo -e "${YELLOW}Typing speed:${NC}  ${YELLOW}$wpm WPM${NC}"  
  else  
    echo -e "${YELLOW}Typing speed:${NC}  ${RED}$wpm WPM${NC}"  
  fi  
  
  if (( $(echo "$accuracy >= 90" | bc -l) )); then  
    echo -e "${YELLOW}Accuracy:${NC}      ${GREEN}$accuracy%${NC}"  
  elif (( $(echo "$accuracy >= 70" | bc -l) )); then  
    echo -e "${YELLOW}Accuracy:${NC}      ${YELLOW}$accuracy%${NC}"  
  else  
    echo -e "${YELLOW}Accuracy:${NC}      ${RED}$accuracy%${NC}"  
  fi  
  
  # Add motivational message based on performance  
  if (( $(echo "$wpm >= 60 && $accuracy >= 95" | bc -l) )); then  
    echo -e "\n${MAGENTA}★ Professional typist level! ★${NC}"  
  elif (( $(echo "$wpm >= 40 && $accuracy >= 90" | bc -l) )); then  
    echo -e "\n${GREEN}Great job! You're above average!${NC}"  
  elif (( $(echo "$wpm < 20 || $accuracy < 70" | bc -l) )); then  
    echo -e "\n${CYAN}Keep practicing! You'll improve with time.${NC}"  
  else  
    echo -e "\n${BLUE}Good effort! Try to beat your score next time.${NC}"  
  fi  
}  

# Main test function with difficulty levels  
typing_test() {  
  clear  
  echo -e "${CYAN}Select difficulty level:${NC}"  
  echo -e "1. ${GREEN}Easy${NC}"  
  echo -e "2. ${YELLOW}Medium${NC}"  
  echo -e "3. ${RED}Hard${NC}"  
  echo -n "Your choice (1-3): "  
  read -n 1 difficulty_choice  
  echo  
  
  case $difficulty_choice in  
    1) difficulty="easy";;  
    2) difficulty="medium";;  
    3) difficulty="hard";;  
    *) difficulty="medium";;  
  esac  
  
  local sentence=$(get_random_sentence "$difficulty")  
  local word_count=$(count_words "$sentence")  
  
  clear  
  echo -e "${CYAN}Type the following sentence:${NC}"  
  echo -e "${YELLOW}Difficulty: ${difficulty^}${NC}\n"  
  
  # Display the sentence with a typewriter effect  
  animate_text "  \"$sentence\""  
  
  echo -e "\n${BLUE}Press Enter when you're ready to start...${NC}"  
  read -s  
  
  # Countdown before starting  
  for i in {3..1}; do  
    echo -ne "${RED}$i... ${NC}"  
    sleep 1  
  done  
  echo -e "${GREEN}GO!${NC}\n"  
  
  start_time=$(date +%s.%N)  
  echo -n "> "  
  read -e -i "" typed_text  
  end_time=$(date +%s.%N)  
  
  # Calculate time with decimal precision  
  time_taken=$(echo "$end_time - $start_time" | bc | awk '{printf "%.2f", $0}')  
  wpm=$(calculate_wpm $word_count $time_taken)  
  accuracy=$(calculate_accuracy "$typed_text" "$sentence")  
  
  display_results "$sentence" "$typed_text" "$time_taken" "$wpm" "$accuracy"  
  
  # Store results for statistics  
  wpm_values+=("$wpm")  
  accuracy_values+=("$accuracy")  
  difficulty_levels+=("$difficulty_choice")  
}  

# Display statistics with visual elements  
display_stats() {  
  if [ ${#wpm_values[@]} -eq 0 ]; then  
    echo -e "${RED}No tests completed yet.${NC}"  
    return  
  fi  

  local sum_wpm=0  
  local sum_accuracy=0  
  local count=${#wpm_values[@]}  
  
  # Calculate best WPM  
  local best_wpm=${wpm_values[0]}  
  for wpm in "${wpm_values[@]}"; do  
    if (( $(echo "$wpm > $best_wpm" | bc -l) )); then  
      best_wpm=$wpm  
    fi  
    sum_wpm=$(echo "$sum_wpm + $wpm" | bc)  
  done  
  
  # Calculate best accuracy  
  local best_accuracy=${accuracy_values[0]}  
  for accuracy in "${accuracy_values[@]}"; do  
    if (( $(echo "$accuracy > $best_accuracy" | bc -l) )); then  
      best_accuracy=$accuracy  
    fi  
    sum_accuracy=$(echo "$sum_accuracy + $accuracy" | bc)  
  done  
  
  local avg_wpm=$(echo "scale=2; $sum_wpm / $count" | bc)  
  local avg_accuracy=$(echo "scale=2; $sum_accuracy / $count" | bc)  
  
  # Difficulty breakdown  
  local easy_count=0 medium_count=0 hard_count=0  
  for level in "${difficulty_levels[@]}"; do  
    case $level in  
      1) ((easy_count++));;  
      2) ((medium_count++));;  
      3) ((hard_count++));;  
    esac  
  done  

  echo -e "\n${CYAN}╔══════════════════════════════╗"  
  echo -e "║       ${YELLOW}SESSION STATISTICS${CYAN}       ║"  
  echo -e "╠══════════════════════════════╣"  
  echo -e "║ ${BLUE}Tests completed:${NC} ${MAGENTA}$count${CYAN}          ║"  
  echo -e "║ ${BLUE}Average WPM:${NC} ${YELLOW}$avg_wpm${CYAN}                ║"  
  echo -e "║ ${BLUE}Average Accuracy:${NC} ${YELLOW}$avg_accuracy%${CYAN}        ║"  
  echo -e "║ ${BLUE}Best WPM:${NC} ${GREEN}$best_wpm${CYAN}                  ║"  
  echo -e "║ ${BLUE}Best Accuracy:${NC} ${GREEN}$best_accuracy%${CYAN}          ║"  
  echo -e "╠══════════════════════════════╣"  
  echo -e "║ ${BLUE}Difficulty Breakdown:${NC}           ║"  
  echo -e "║ ${GREEN}Easy:${NC} $easy_count  ${YELLOW}Medium:${NC} $medium_count  ${RED}Hard:${NC} $hard_count ║"  
  echo -e "╚══════════════════════════════╝${NC}"  
}  

# Display welcome screen  
welcome_screen() {  
  clear  
  echo -e "${CYAN}╔══════════════════════════════════════════╗"  
  echo -e "║${YELLOW}          TYPING MASTER CHALLENGE          ${CYAN}║"  
  echo -e "╠══════════════════════════════════════════╣"  
  echo -e "║${BLUE}  Test and improve your typing skills!      ${CYAN}║"  
  echo -e "║${BLUE}  • Multiple difficulty levels              ${CYAN}║"  
  echo -e "║${BLUE}  • Detailed performance analysis          ${CYAN}║"  
  echo -e "║${BLUE}  • Track your progress                     ${CYAN}║"  
  echo -e "╚══════════════════════════════════════════╝${NC}"  
  echo -e "\n${MAGENTA}Get ready to boost your typing speed and accuracy!${NC}"  
  sleep 2  
}  

# Main loop  
wpm_values=()  
accuracy_values=()  
difficulty_levels=()  

welcome_screen  

while true; do  
  clear  
  echo -e "${CYAN}╔══════════════════════════════╗"  
  echo -e "║       ${YELLOW}TYPING TEST${CYAN}            ║"  
  echo -e "╠══════════════════════════════╣"  
  echo -e "║ ${GREEN}1. Start new test${NC}             ${CYAN}║"  
  echo -e "║ ${YELLOW}2. View statistics${NC}           ${CYAN}║"  
  echo -e "║ ${RED}3. Exit${NC}                     ${CYAN}║"  
  echo -e "╚══════════════════════════════╝${NC}"  
  echo -n -e "${BLUE}Choose option (1-3): ${NC}"  
  read -n 1 choice  
  echo  

  case $choice in  
    1)  
      typing_test  
      ;;  
    2)  
      display_stats  
      ;;  
    3)  
      echo -e "\n${MAGENTA}Thank you for using the Typing Master Challenge!${NC}"  
      echo -e "${YELLOW}Keep practicing to become a typing champion!${NC}\n"  
      break  
      ;;  
    *)  
      echo -e "${RED}Invalid option. Please try again.${NC}"  
      ;;  
  esac  

  if [ "$choice" != "3" ]; then  
    echo -ne "\n${BLUE}Press any key to continue...${NC}"  
    read -n 1 -s  
  fi  
done  *