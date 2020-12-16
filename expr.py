import random

def expr(depth):
    if depth==1: 
        return random.choice(['', '-']) + str(int(random.choice(range(1,999))))
    exp1 =  expr(depth-1)
    exp2 = expr(depth-1)
    #if eval(exp1) % eval(exp2) == 0:
    #    return  '(' + exp1 + '/' + exp2 + ')'
    return '(' + exp1 + random.choice(['+','-','*']) + exp2 + ')'
    
expr_num = int(input('Enter amount of expressions you want: '))
print("Generating test files")
with open("in.txt" ,'w') as in_file:
    with open("exp.txt", 'w') as exp_file:
        n = 0
        while(n < expr_num):
            exp = expr(random.choice(range(1,10)))
            try:
                res = eval(exp)
                if abs(res) > 2147483647:
                    continue
            except:
                continue
            if(res != 0):
                n += 1
                in_file.write(exp +"\n")
                exp_file.write("Result is: " + str(res) + "\n")