.text
# Back-to-back ALU dependencies exercise EX/MEM and MEM/WB forwarding.
addi $t0, $zero, 5
addi $t1, $zero, 3
add  $t2, $t0, $t1
and  $t3, $t2, $t0
add  $t4, $t2, $t1
add  $t5, $t4, $t2
and  $t6, $t5, $t4
add  $s0, $t6, $t1
and  $s1, $s0, $t0
add  $s2, $s1, $t2
sw   $s2, 0($zero)
sw   $zero, 252($zero)
