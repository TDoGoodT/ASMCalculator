import random

def expr(depth):
    if depth==1 or random.random()<1.0/(2**depth-1): 
        return str(int(random.random() * 100))
    return '(' + expr(depth-1) + random.choice(['+','-','*','/']) + expr(depth-1) + ')'
    
expr_num = int(input('Enter amount of expressions you want: '))
print("Generating...")
with open("in.txt" ,'w') as in_file:
    with open("exp.txt", 'w') as exp_file:
        n = 0
        while(n < expr_num):
            exp = expr(random.choice(range(5,15)))
            try:
                res = eval(exp)
            except:
                continue
            if(res != 0):
                n += 1
                in_file.write(exp +"\n")
                exp_file.write(str(res) + "\n")
               
print("Done, please look at \"in.txt\" and \"exp.txt\" ")