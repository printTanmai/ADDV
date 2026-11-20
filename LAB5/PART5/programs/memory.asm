.text
# Stores establish deterministic data; each LW consumer tests a load-use stall.
addi $t0, $zero, 7
addi $t1, $zero, 11
sw   $t0, 0($zero)
sw   $t1, 4($zero)
lw   $t2, 0($zero)
add  $t3, $t2, $t1
lw   $t4, 4($zero)
and  $t5, $t4, $t3
add  $s0, $t3, $t5
sw   $s0, 8($zero)
lw   $s1, 8($zero)
add  $s2, $s1, $t0
sw   $s2, 12($zero)
lw   $s3, 12($zero)
and  $s4, $s3, $t1
sw   $s4, 16($zero)
sw   $zero, 252($zero)
