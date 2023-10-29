import unittest
import torch
from tracing import NeuralNetwork, train_model, test_model

class MockDataset:
    def __init__(self, data):
        self.data = data

    def __len__(self):
        return len(self.data)

class MockLoader:
    def __init__(self, dataset, batch_size=64):
        self.dataset = dataset
        self.batch_size = batch_size

    def __iter__(self):
        return iter(self.dataset.data)

    def __len__(self):
        return (len(self.dataset) + self.batch_size - 1) // self.batch_size  # Ceiling division to handle the last batch


class TestTrainingAndTesting(unittest.TestCase):
    def setUp(self):
        self.model = NeuralNetwork()
        self.device = torch.device("cuda" if torch.cuda.is_available() else "cpu")
        self.optimizer = torch.optim.SGD(self.model.parameters(), lr=0.01, momentum=0.5)

        # Mocking the data loaders
        train_data = [(torch.randn(64, 1, 28, 28), torch.randint(0, 10, (64,))) for _ in range(10)]
        mock_train_dataset = MockDataset(train_data)
        self.mock_train_loader = MockLoader(mock_train_dataset)

        test_data = [(torch.randn(1000, 1, 28, 28), torch.randint(0, 10, (1000,))) for _ in range(10)]
        mock_test_dataset = MockDataset(test_data)
        self.mock_test_loader = MockLoader(mock_test_dataset)

        batch_size = 64
        self.mock_train_loader = MockLoader(mock_train_dataset, batch_size=batch_size)
        self.mock_test_loader = MockLoader(mock_test_dataset, batch_size=1000)  # Adjust the batch size as needed

    def test_train_model(self):
        initial_state_dict = {name: param.clone() for name, param in self.model.state_dict().items()}
        loss = train_model(self.model, self.device, self.mock_train_loader, self.optimizer, 1)

        # Check that at least one parameter has changed after training
        for name, param in self.model.state_dict().items():
            self.assertFalse(torch.equal(initial_state_dict[name], param),
                             f"Parameter {name} did not change during training")

        self.assertIsInstance(loss, float)  # Loss should be a float value

    def test_test_model(self):
        test_loss, accuracy = test_model(self.model, self.device, self.mock_test_loader)
        self.assertIsInstance(test_loss, float)  # Test loss should be a float value
        self.assertIsInstance(accuracy, float)  # Accuracy should be a float value

if __name__ == '__main__':
    unittest.main()
