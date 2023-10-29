import unittest
import torch
from tracing import NeuralNetwork

class TestNeuralNetwork(unittest.TestCase):
    def setUp(self):
        self.model = NeuralNetwork()

    def test_initialization(self):
        self.assertIsInstance(self.model.conv_layer1, torch.nn.modules.conv.Conv2d)
        self.assertIsInstance(self.model.conv_layer2, torch.nn.modules.conv.Conv2d)
        self.assertIsInstance(self.model.conv_layer2_dropout, torch.nn.modules.dropout.Dropout2d)
        self.assertIsInstance(self.model.fc_layer1, torch.nn.modules.linear.Linear)
        self.assertIsInstance(self.model.fc_layer2, torch.nn.modules.linear.Linear)

    def test_forward_pass(self):
        input_tensor = torch.randn(1, 1, 28, 28)  # Random tensor of the same shape as MNIST images
        output = self.model(input_tensor)
        self.assertEqual(output.shape, (1, 10))  # The output should be a tensor of shape (batch_size, num_classes)

if __name__ == '__main__':
    unittest.main()
