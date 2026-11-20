.text
# The first and fourth BEQs are taken; the middle two are not taken.
addi $t0, $zero, 5
addi $t1, $zero, 5
addi $t2, $zero, 7
beq  $t0, $t1, taken_one
addi $s0, $zero, 99
addi $s1, $zero, 98
taken_one:
addi $s0, $zero, 1
beq  $t0, $t2, taken_two
addi $s1, $zero, 2
add  $s2, $s0, $s1
beq  $s2, $t2, taken_two
and  $s3, $s2, $s1
beq  $t0, $t1, taken_two
addi $s4, $zero, 77
addi $s5, $zero, 88
taken_two:
add  $s4, $s2, $s3
sw   $s4, 16($zero)
sw   $zero, 252($zero)
