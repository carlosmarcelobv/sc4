#faz clareamento (ou escurecimento) de imagem grayscale de maneira uniforme
#serve para bmp, jpg e png, com melhores resultados para bmp

#cm 11/23 - v01 - #versão inicial - www.familiaquadrada.com

import cv2
import numpy as np
import os

# caminho padrão
imgpath = 'c:\\armario\\'

# nome da imagem origem
imgcrua = 'a reference g q257 grayscaled'
imgcruaext = '.bmp'

# nome da imagem destino
imgcozida = imgcrua + '_modificado'

# clarear (positivo) ou escurecer (usar valores negativos) por faixa de terra e água
#caso queira a mudança por toda imagem, é só zerar "aguaaa"
terra = 20
aguaa = 10

# carrega a imagem em escala de cinza
img = cv2.imread(imgpath + imgcrua + imgcruaext, cv2.IMREAD_GRAYSCALE)

# máscaras: alterar a altura de forma diferente entre terra e água
# se quiser elevar todo o terreno, use zero
nivelterra = 83
mskterra = img > nivelterra
mskaguaa = img <= nivelterra

# aumenta a claridade adicionando um valor constante aos pixels correspondentes
img[mskterra] = cv2.add(img[mskterra], terra, img[mskterra]).astype('uint8')
img[mskaguaa] = cv2.add(img[mskaguaa], aguaa, img[mskaguaa]).astype('uint8')

# verifica se o arquivo de destino, cozido, já existe, caso não, ele cria sempre incrementando o número no final do nome
i = 0
while os.path.exists(imgpath + imgcozida + str(i) + imgcruaext):
    i += 1

# Salva a imagem resultante
cv2.imwrite(imgpath + imgcozida + str(i) + imgcruaext, img)

