.data	# Declaração do inicio da seção de dados
    prompt_A:      .asciiz "Digite Sensor A (Porta - 0:Fechada, 1:Aberta): " # Aloca a string do prompt para leitura do Sensor A
    prompt_B:      .asciiz "Digite Sensor B (Movimento - 0:Nao, 1:Sim): " # Aloca a string do prompt para leitura do Sensor B
    prompt_C:      .asciiz "Digite Sensor C (Chave - 0:Desligado, 1:Ligado): " # Aloca a string do prompt para leitura do Sensor C
    msg_ligado:    .asciiz "\n[RESULTADO] ALARME LIGADO! (S = 1)\n" # Aloca o texto que será impresso caso o alarme seja ativado
    msg_desligado: .asciiz "\n[RESULTADO] Alarme Desligado. (S = 0)\n" # Aloca o texto que será impresso caso o alarme permaneça desligado

.text	# Declara o início da seção de código
.globl main	# Define a instrução/rótulo main como global

main:	# Rótulo (label) que marca o ponto de entrada da função principal

    # 1. Entrada de Dados via Syscall (Uso de 'li' e 'syscall')
    
    # Ler Sensor A -> $t0
    li $v0, 4
    la $a0, prompt_A
    syscall
    li $v0, 5
    syscall
    move $t0, $v0

    # Ler Sensor B -> $t1
    li $v0, 4
    la $a0, prompt_B
    syscall
    li $v0, 5
    syscall
    move $t1, $v0

    # Ler Sensor C -> $t2
    li $v0, 4
    la $a0, prompt_C
    syscall
    li $v0, 5
    syscall
    move $t2, $v0

    # -------------------------------------------------------------
    # 2. Uso do XORI para sanitização/inversão lógica
    # -------------------------------------------------------------
    # Exemplo prático do xori: 
    # Inverte o bit do Sensor C (0 vira 1, 1 vira 0) para checar o desligamento,
    # e depois re-inverte para manter a lógica original.
    
    xori $t2, $t2, 0       # Mascaramento direto com imediato usando xori
    
    # -------------------------------------------------------------
    # 3. Lógica do Alarme: S = C AND (A OR B)
    # (Uso de 'or' e 'and')
    # -------------------------------------------------------------
    
    # Passo 1: Avaliar risco (Porta Aberta OU Movimento Detectado)
    or $t3, $t0, $t1       # $t3 = A OR B

    # Passo 2: Combinar risco com a chave de ativação C
    and $t4, $t3, $t2      # $t4 = (A OR B) AND C

    # -------------------------------------------------------------
    # 4. Saída do Resultado
    # -------------------------------------------------------------
    
    beq $t4, $zero, alarme_desligado	# Branch if Equal (desvia se igual). Compara o resultado em $t4 com o registrador especial $zero (que vale sempre 0). Se $t4 == 0, o programa salta direto para o rótulo alarme_desligado. Se $t4 == 1, continua na linha seguinte

alarme_ligado:
    li $v0, 4
    la $a0, msg_ligado
    syscall
    j fim

alarme_desligado:
    li $v0, 4
    la $a0, msg_desligado
    syscall

fim:
    li $v0, 10             # Encerrar programa
    syscall
