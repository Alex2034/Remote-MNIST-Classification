import argparse
import torch
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
from torchvision import datasets, transforms
import os

class NeuralNetwork(nn.Module):
    def __init__(self):
        super(NeuralNetwork, self).__init__()
        self.conv_layer1 = nn.Conv2d(1, 10, kernel_size=5)
        self.conv_layer2 = nn.Conv2d(10, 20, kernel_size=5)
        self.conv_layer2_dropout = nn.Dropout2d()
        self.fc_layer1 = nn.Linear(320, 50)
        self.fc_layer2 = nn.Linear(50, 10)

    def forward(self, x):
        x = F.relu(F.max_pool2d(self.conv_layer1(x), 2))
        x = F.relu(F.max_pool2d(self.conv_layer2_dropout(self.conv_layer2(x)), 2))
        x = x.view(-1, 320)
        x = F.relu(self.fc_layer1(x))
        x = F.dropout(x, training=self.training)
        x = self.fc_layer2(x)
        return F.log_softmax(x, dim=1)

def train_model(model, device, train_loader, optimizer, epoch, epochs):
    model.train()
    for batch_idx, (data, target) in enumerate(train_loader):
        data, target = data.to(device), target.to(device)
        optimizer.zero_grad()
        output = model(data)
        loss = F.nll_loss(output, target)
        loss.backward()
        optimizer.step()
        if batch_idx == 0:
            print(f'Training Epoch: {epoch}/{epochs} [{batch_idx * len(data)}/{len(train_loader.dataset)} ({100. * batch_idx / len(train_loader):.0f}%)]\tLoss: {loss.item():.6f}')
    return loss.item()

def test_model(model, device, test_loader):
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += F.nll_loss(output, target, reduction='sum').item() 
            pred = output.max(1, keepdim=True)[1] 
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)
    accuracy = 100. * correct / len(test_loader.dataset)
    print(f'\nTest set: Average loss: {test_loss:.4f}, Accuracy: {correct}/{len(test_loader.dataset)} ({100. * correct / len(test_loader.dataset):.0f}%)\n')
    return test_loss, accuracy

def parse_args():
    parser = argparse.ArgumentParser(description='PyTorch MNIST Example')
    parser.add_argument('--batch-size', type=int, default=64, metavar='N',
                        help='input batch size for training (default: 64)')
    parser.add_argument('--test-batch-size', type=int, default=1000, metavar='N',
                        help='input batch size for testing (default: 1000)')
    parser.add_argument('--epochs', type=int, default=10, metavar='N',
                        help='number of epochs to train (default: 10)')
    parser.add_argument('--lr', type=float, default=0.01, metavar='LR',
                        help='learning rate (default: 0.01)')
    parser.add_argument('--momentum', type=float, default=0.5, metavar='M',
                        help='SGD momentum (default: 0.5)')
    parser.add_argument('--no-cuda', action='store_true', default=False,
                        help='disables CUDA training')
    parser.add_argument('--seed', type=int, default=1, metavar='S',
                        help='random seed (default: 1)')
    parser.add_argument('--log-interval', type=int, default=10, metavar='N',
                        help='how many batches to wait before logging training status')

    return parser.parse_args()

def main(args):
    use_cuda = not args.no_cuda and torch.cuda.is_available()
    print(use_cuda)
    torch.manual_seed(args.seed)

    device = torch.device("cuda" if use_cuda else "cpu")

    kwargs = {'num_workers': 8, 'pin_memory': True} if use_cuda else {}
    train_loader = torch.utils.data.DataLoader(
        datasets.MNIST(os.getcwd()+'/data', train=True, download=True,
                       transform=transforms.Compose([
                           transforms.ToTensor(),
                           transforms.Normalize((0.1307,), (0.3081,))
                       ])),
        batch_size=args.batch_size, shuffle=True, **kwargs)
    test_loader = torch.utils.data.DataLoader(
        datasets.MNIST(os.getcwd()+'/data', train=False, transform=transforms.Compose([
                           transforms.ToTensor(),
                           transforms.Normalize((0.1307,), (0.3081,))
                       ])),
        batch_size=args.test_batch_size, shuffle=True, **kwargs)


    model = NeuralNetwork().to(device)
    optimizer = optim.SGD(model.parameters(), lr=args.lr, momentum=args.momentum)

    for epoch in range(1, args.epochs + 1):
        train_model(model, device, train_loader, optimizer, epoch, args.epochs)
        test_model(model, device, test_loader)

    torch.save(model, "model.pth")

def create_traced_model(model, random_input):
    traced_model = torch.jit.trace(model, random_input)
    traced_model.save("model_trace.pt")
    print("Success - model_trace was saved!")


def save_model():
    use_cuda = torch.cuda.is_available()
    mnist_testset = datasets.MNIST(root=os.getcwd()+'/data', train=False, download=True, transform=None)
    train_image, _ = mnist_testset[24]
    train_image.show()

    device = torch.device("cuda" if use_cuda else "cpu")
    model = torch.load("model.pth").to(device)
    loader = transforms.Compose([
                           transforms.ToTensor(),
                           transforms.Normalize((0.1307,), (0.3081,))
                       ])
    tensor_image = loader(train_image).unsqueeze(0).to(device)
    output = model(tensor_image)
    pred = output.max(1, keepdim=True)[1]
    pred = torch.squeeze(pred)

    print("Success")

    # TRACING THE MODEL: comment out if you don't want to save the traced model in a demo run
    create_traced_model(model, tensor_image)

if __name__ == '__main__':
    # main() creates the model.pth. save_model() takes the model.pth and random input and creates model.pt.
    args = parse_args()
    main(args)
    save_model()